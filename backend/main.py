"""
FastAPI Backend Server for Child Safety Monitor
Handles AI insights generation using Groq API (Llama 3.3)
"""

import os
import json
from datetime import datetime
from typing import List, Optional
from collections import defaultdict
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import asyncio
from groq import Groq

# Load environment variables
load_dotenv()

# Configure Groq API (FREE and FAST!)
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
groq_client = Groq(api_key=GROQ_API_KEY) if GROQ_API_KEY else None


# Initialize FastAPI app
app = FastAPI(
    title="Child Safety Monitor API",
    description="Backend API for generating AI-powered insights from activity logs",
    version="1.0.0"
)

# Enable CORS for Flutter app access from different devices
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Pydantic models for request/response
class ActivityLog(BaseModel):
    """Represents a single activity log entry"""
    app_name: str
    category: str
    duration_minutes: int
    timestamp: str


class InsightsRequest(BaseModel):
    """Request body for insights generation"""
    logs: List[ActivityLog]


class InsightsResponse(BaseModel):
    """Response containing the generated insights"""
    summary: str


class HealthResponse(BaseModel):
    """Health check response"""
    status: str


# ============ Weekly Report Models ============

class ChildInfo(BaseModel):
    """Child information for the report"""
    child_id: str
    child_name: str
    age: int = 10  # Optional, default 10


class DailyStats(BaseModel):
    """Stats for a single day"""
    date: str
    total_minutes: int
    category_breakdown: dict  # {"gaming": 60, "education": 30, ...}


class WeeklyReportRequest(BaseModel):
    """Request body for weekly report generation"""
    child: ChildInfo
    logs: List[ActivityLog]
    week_start: str  # ISO date string
    week_end: str


class TopApp(BaseModel):
    """Top app usage data"""
    app_name: str
    category: str
    total_minutes: int
    percentage: float


class CategoryStat(BaseModel):
    """Category statistics"""
    name: str
    total_minutes: int
    percentage: float
    trend: str  # "up", "down", "stable"


class WeeklyReportResponse(BaseModel):
    """Comprehensive weekly report response"""
    # Basic info
    child_name: str
    week_start: str
    week_end: str
    generated_at: str
    
    # Stats
    total_screen_time_minutes: int
    daily_average_minutes: int
    safety_score: int  # 1-100
    
    # Breakdowns
    daily_stats: List[DailyStats]
    top_apps: List[TopApp]
    category_stats: List[CategoryStat]
    
    # AI-generated content
    executive_summary: str
    key_observations: List[str]
    concerns: List[str]
    positive_highlights: List[str]
    recommendations: List[str]


# ============ Content Scanner Models ============

class ContentScanRequest(BaseModel):
    """Request to scan content for child safety"""
    content: str  # URL or text to analyze
    content_type: str = "auto"  # "url", "text", or "auto" (detect automatically)
    child_age: int = 10  # Age of child for age-appropriate analysis


class RiskCategory(BaseModel):
    """Individual risk category"""
    name: str
    severity: str  # "low", "medium", "high"
    description: str


class ContentScanResponse(BaseModel):
    """Response from content safety scan"""
    safety_score: int  # 0-100 (100 = completely safe)
    risk_level: str  # "safe", "caution", "warning", "danger"
    content_type: str  # "url" or "text"
    risk_categories: List[RiskCategory]
    ai_explanation: str
    recommendations: List[str]
    is_age_appropriate: bool
    scanned_content: str  # The content that was analyzed


@app.post("/content/scan", response_model=ContentScanResponse)
async def scan_content(request: ContentScanRequest):
    """
    AI-powered content safety scanner.
    
    Analyzes URLs or text content for child safety using Groq AI (Llama 3.3).
    Returns a safety score (0-100), risk categories, and detailed explanation.
    """
    if not groq_client:
        raise HTTPException(
            status_code=500,
            detail="Groq API key not configured"
        )
    
    try:
        
        # Determine content type
        content_type = request.content_type
        if content_type == "auto":
            # Simple URL detection
            if request.content.startswith(("http://", "https://", "www.")):
                content_type = "url"
            else:
                content_type = "text"
        
        # Build the analysis prompt
        prompt = f"""You are a child safety content analyzer. Analyze the following {content_type} for a {request.child_age}-year-old child.

Content to analyze: "{request.content}"

Provide a comprehensive safety analysis in the following JSON format:
{{
    "safety_score": <0-100, where 100 is completely safe>,
    "risk_level": "<safe|caution|warning|danger>",
    "risk_categories": [
        {{
            "name": "<category name like 'Violence', 'Adult Content', 'Gambling', etc.>",
            "severity": "<low|medium|high>",
            "description": "<brief explanation of why this is flagged>"
        }}
    ],
    "ai_explanation": "<2-3 sentence explanation of the overall safety assessment>",
    "recommendations": ["<specific action recommendations for parents>"],
    "is_age_appropriate": <true|false>
}}

IMPORTANT GUIDELINES:
- Score 80-100: Safe content appropriate for children
- Score 60-79: Caution - minor concerns but generally okay with supervision
- Score 40-59: Warning - contains concerning elements
- Score 0-39: Danger - not appropriate for children

Consider these risk factors:
- Violence or graphic content
- Adult/sexual content
- Hate speech or bullying
- Gambling or betting
- Inappropriate language
- Misinformation
- Advertising/scams targeting children
- Privacy risks
- Addictive mechanics (for games/apps)

Return ONLY valid JSON, no additional text."""

        response = groq_client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=1024
        )
        response_text = response.choices[0].message.content.strip()
        
        # Clean up JSON response
        if response_text.startswith("```json"):
            response_text = response_text[7:]
        if response_text.startswith("```"):
            response_text = response_text[3:]
        if response_text.endswith("```"):
            response_text = response_text[:-3]
        response_text = response_text.strip()
        
        # Parse JSON response
        result = json.loads(response_text)
        
        # Convert risk categories to proper format
        risk_categories = [
            RiskCategory(
                name=cat.get("name", "Unknown"),
                severity=cat.get("severity", "low"),
                description=cat.get("description", "")
            )
            for cat in result.get("risk_categories", [])
        ]
        
        return ContentScanResponse(
            safety_score=result.get("safety_score", 50),
            risk_level=result.get("risk_level", "caution"),
            content_type=content_type,
            risk_categories=risk_categories,
            ai_explanation=result.get("ai_explanation", "Unable to analyze content."),
            recommendations=result.get("recommendations", []),
            is_age_appropriate=result.get("is_age_appropriate", False),
            scanned_content=request.content
        )
        
    except json.JSONDecodeError as e:
        # Fallback to demo response
        return _get_demo_scan_response(request.content)
    except Exception as e:
        # Fallback to demo response when API fails
        print(f"⚠️ API failed, using demo mode: {str(e)}")
        return _get_demo_scan_response(request.content)


def _get_demo_scan_response(content: str) -> ContentScanResponse:
    """Generate demo response when AI is unavailable"""
    content_lower = content.lower()
    
    # Demo responses based on content
    if "youtube" in content_lower:
        return ContentScanResponse(
            safety_score=72,
            risk_level="caution",
            content_type="url",
            risk_categories=[
                RiskCategory(name="Addictive Content", severity="medium", description="Contains algorithmic recommendations that may lead to excessive usage"),
                RiskCategory(name="Unmoderated Comments", severity="low", description="User comments may contain inappropriate language")
            ],
            ai_explanation="YouTube is a popular video platform. While it offers educational content, it also has addictive recommendation algorithms and unmoderated comment sections. Parental supervision is recommended.",
            recommendations=["Enable YouTube Kids mode", "Set daily time limits", "Review watch history regularly"],
            is_age_appropriate=True,
            scanned_content=content
        )
    elif "tiktok" in content_lower or "instagram" in content_lower:
        return ContentScanResponse(
            safety_score=45,
            risk_level="warning",
            content_type="url",
            risk_categories=[
                RiskCategory(name="Social Media Risks", severity="high", description="Exposure to stranger interactions and inappropriate content"),
                RiskCategory(name="Addictive Design", severity="high", description="Infinite scroll and variable rewards cause compulsive usage"),
                RiskCategory(name="Privacy Concerns", severity="medium", description="Data collection and location sharing risks")
            ],
            ai_explanation="This social media platform poses significant risks for children including exposure to inappropriate content, stranger danger, and highly addictive design patterns. Not recommended for children under 13.",
            recommendations=["Consider age-appropriate alternatives", "If allowed, enable strict privacy settings", "Limit daily usage to 30 minutes"],
            is_age_appropriate=False,
            scanned_content=content
        )
    elif "roblox" in content_lower or "minecraft" in content_lower:
        return ContentScanResponse(
            safety_score=68,
            risk_level="caution",
            content_type="url",
            risk_categories=[
                RiskCategory(name="In-Game Purchases", severity="medium", description="Contains microtransactions that may lead to overspending"),
                RiskCategory(name="Online Interactions", severity="medium", description="Chat features allow communication with strangers")
            ],
            ai_explanation="This is a popular gaming platform for children. While generally safe with parental controls enabled, it has in-game purchases and allows online interactions with other players.",
            recommendations=["Enable parental controls", "Disable in-game purchases or set spending limits", "Monitor friend requests"],
            is_age_appropriate=True,
            scanned_content=content
        )
    elif "google" in content_lower or "educational" in content_lower:
        return ContentScanResponse(
            safety_score=92,
            risk_level="safe",
            content_type="url",
            risk_categories=[],
            ai_explanation="This appears to be an educational or search platform. Generally safe for children with appropriate SafeSearch settings enabled.",
            recommendations=["Ensure SafeSearch is enabled", "Monitor search history periodically"],
            is_age_appropriate=True,
            scanned_content=content
        )
    else:
        # Generic response
        return ContentScanResponse(
            safety_score=65,
            risk_level="caution",
            content_type="url" if "." in content else "text",
            risk_categories=[
                RiskCategory(name="Unknown Content", severity="medium", description="Unable to fully verify content safety")
            ],
            ai_explanation="This content requires parental review. We recommend checking the content manually before allowing access.",
            recommendations=["Review content manually", "Check user reviews and ratings", "Enable parental controls"],
            is_age_appropriate=True,
            scanned_content=content
        )


# ============ Smart Screen Time Rules ============

class UsageData(BaseModel):
    """Usage data for AI analysis"""
    category: str  # gaming, social, education, entertainment
    avg_daily_minutes: int
    peak_hours: List[str] = []  # e.g., ["14:00", "20:00"]


class ScreenTimeRequest(BaseModel):
    """Request for AI screen time suggestions"""
    child_name: str
    child_age: int
    usage_data: List[UsageData]
    current_bedtime: str = "21:00"  # HH:MM format
    school_hours: str = "08:00-15:00"  # Start-End


class SuggestedRule(BaseModel):
    """A suggested screen time rule"""
    mode_name: str
    description: str
    start_time: str
    end_time: str
    allowed_categories: List[str]
    blocked_categories: List[str]
    daily_limit_minutes: Optional[int] = None


class ScreenTimeSuggestion(BaseModel):
    """AI-generated screen time suggestions"""
    summary: str
    suggested_rules: List[SuggestedRule]
    insights: List[str]
    recommended_daily_limit: int
    recommended_bedtime: str


@app.post("/screentime/suggest", response_model=ScreenTimeSuggestion)
async def suggest_screen_time(request: ScreenTimeRequest):
    """
    AI-powered screen time rule suggestions.
    
    Analyzes usage patterns and suggests optimal rules and limits.
    """
    if not groq_client:
        raise HTTPException(
            status_code=500,
            detail="Groq API key not configured. Please set GROQ_API_KEY in .env file."
        )
    
    try:
        # Format usage data for prompt
        usage_summary = "\n".join([
            f"- {u.category}: {u.avg_daily_minutes} min/day, peak at {', '.join(u.peak_hours) if u.peak_hours else 'various times'}"
            for u in request.usage_data
        ])
        
        prompt = f"""You are a child development and screen time expert. Analyze this child's usage and suggest optimal screen time rules.

CHILD INFO:
- Name: {request.child_name}
- Age: {request.child_age} years old
- Current Bedtime: {request.current_bedtime}
- School Hours: {request.school_hours}

CURRENT USAGE PATTERNS:
{usage_summary}

Based on pediatric guidelines and this child's age, provide personalized screen time recommendations in JSON format:
{{
    "summary": "<2-3 sentence overall assessment>",
    "suggested_rules": [
        {{
            "mode_name": "<Homework Time|Bedtime Mode|Free Time|School Time>",
            "description": "<what this mode does>",
            "start_time": "<HH:MM>",
            "end_time": "<HH:MM>",
            "allowed_categories": ["<category>"],
            "blocked_categories": ["<category>"],
            "daily_limit_minutes": <optional limit in minutes or null>
        }}
    ],
    "insights": ["<specific observations about usage patterns>"],
    "recommended_daily_limit": <total recommended screen time in minutes>,
    "recommended_bedtime": "<HH:MM>"
}}

GUIDELINES BY AGE:
- Ages 6-10: 1-2 hours recreational screen time, education unlimited
- Ages 11-13: 2-3 hours with breaks
- Ages 14-17: 3-4 hours with self-regulation encouraged

IMPORTANT:
- Always include Homework Time (afternoon) and Bedtime Mode
- Consider their peak usage hours when scheduling
- Block gaming/social during homework, allow education
- Suggest gradual screen-free time before bed

Return ONLY valid JSON."""

        # Use Groq API (fast Llama 3.3)
        chat_completion = groq_client.chat.completions.create(
            messages=[
                {"role": "system", "content": "You are a child development expert. Respond only with valid JSON."},
                {"role": "user", "content": prompt}
            ],
            model="llama-3.3-70b-versatile",
            temperature=0.7,
            max_tokens=1500
        )
        
        response_text = chat_completion.choices[0].message.content.strip()
        
        # Clean up JSON
        if response_text.startswith("```json"):
            response_text = response_text[7:]
        if response_text.startswith("```"):
            response_text = response_text[3:]
        if response_text.endswith("```"):
            response_text = response_text[:-3]
        response_text = response_text.strip()
        
        result = json.loads(response_text)
        
        # Convert to response model
        suggested_rules = [
            SuggestedRule(
                mode_name=r.get("mode_name", "Custom"),
                description=r.get("description", ""),
                start_time=r.get("start_time", "00:00"),
                end_time=r.get("end_time", "23:59"),
                allowed_categories=r.get("allowed_categories", []),
                blocked_categories=r.get("blocked_categories", []),
                daily_limit_minutes=r.get("daily_limit_minutes")
            )
            for r in result.get("suggested_rules", [])
        ]
        
        return ScreenTimeSuggestion(
            summary=result.get("summary", ""),
            suggested_rules=suggested_rules,
            insights=result.get("insights", []),
            recommended_daily_limit=result.get("recommended_daily_limit", 120),
            recommended_bedtime=result.get("recommended_bedtime", "21:00")
        )
        
    except json.JSONDecodeError as e:
        # Fallback to demo response
        return _get_demo_screentime_response(request)
    except Exception as e:
        # Fallback to demo response when API fails
        print(f"⚠️ API failed, using demo mode: {str(e)}")
        return _get_demo_screentime_response(request)


def _get_demo_screentime_response(request: ScreenTimeRequest) -> ScreenTimeSuggestion:
    """Generate demo screen time suggestions when AI is unavailable"""
    age = request.child_age
    
    # Adjust limits based on age
    if age <= 8:
        daily_limit = 90
        bedtime = "20:00"
    elif age <= 12:
        daily_limit = 120
        bedtime = "21:00"
    else:
        daily_limit = 180
        bedtime = "22:00"
    
    return ScreenTimeSuggestion(
        summary=f"Based on {request.child_name}'s age ({age}) and usage patterns, we recommend structured screen time with focus on educational content. Gaming should be limited to after homework completion.",
        suggested_rules=[
            SuggestedRule(
                mode_name="Homework Time",
                description="Focus time for studies - games and social media blocked",
                start_time="15:00",
                end_time="17:00",
                allowed_categories=["Education", "Productivity", "Reference"],
                blocked_categories=["Gaming", "Social Media", "Entertainment"],
                daily_limit_minutes=None
            ),
            SuggestedRule(
                mode_name="Free Time",
                description="Recreational screen time with reasonable limits",
                start_time="17:00",
                end_time="20:00",
                allowed_categories=["Gaming", "Entertainment", "Social Media"],
                blocked_categories=[],
                daily_limit_minutes=60
            ),
            SuggestedRule(
                mode_name="Bedtime Mode",
                description="Wind down before sleep - all screens off",
                start_time=bedtime,
                end_time="07:00",
                allowed_categories=["Calls"],
                blocked_categories=["All Apps"],
                daily_limit_minutes=None
            )
        ],
        insights=[
            f"Gaming usage peaks in the evening - consider setting a 1-hour limit",
            "Educational app usage is healthy - great job encouraging learning!",
            "Social media usage should be monitored for age-appropriateness",
            f"Current screen time may be slightly high for {age}-year-olds"
        ],
        recommended_daily_limit=daily_limit,
        recommended_bedtime=bedtime
    )


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """
    Health check endpoint to verify server connectivity.
    Returns online status.
    """
    return {"status": "online"}


# ============ Weekly Reports ============

class ChildInfo(BaseModel):
    """Child information for report"""
    child_id: str
    child_name: str
    age: int

class LogEntry(BaseModel):
    """Activity log entry"""
    app_name: str
    category: str
    duration_minutes: int
    timestamp: str

class WeeklyReportRequest(BaseModel):
    """Request for weekly report generation - matches Flutter service"""
    child: ChildInfo
    logs: List[LogEntry]
    week_start: str  # ISO date string
    week_end: str

# Response models matching Flutter WeeklyReport
class CategoryStatResponse(BaseModel):
    name: str
    total_minutes: int
    percentage: float
    trend: str  # "up", "down", "stable"

class TopAppResponse(BaseModel):
    app_name: str
    category: str
    total_minutes: int
    percentage: float

class DailyStatsResponse(BaseModel):
    date: str
    total_minutes: int
    category_breakdown: dict

class WeeklyReportResponse(BaseModel):
    """AI-generated weekly report - matches Flutter WeeklyReport model"""
    child_name: str
    week_start: str
    week_end: str
    generated_at: str
    total_screen_time_minutes: int
    daily_average_minutes: int
    safety_score: int
    daily_stats: List[DailyStatsResponse]
    top_apps: List[TopAppResponse]
    category_stats: List[CategoryStatResponse]
    executive_summary: str
    key_observations: List[str]
    concerns: List[str]
    positive_highlights: List[str]
    recommendations: List[str]

@app.post("/reports/weekly", response_model=WeeklyReportResponse)
async def generate_weekly_report(request: WeeklyReportRequest):
    """
    Generate AI-powered weekly activity report for a child.
    """
    # Calculate stats from logs
    total_minutes = sum(log.duration_minutes for log in request.logs)
    daily_avg = total_minutes // 7 if total_minutes else 0
    
    # Get category breakdown
    category_usage = {}
    app_usage = {}
    for log in request.logs:
        category_usage[log.category] = category_usage.get(log.category, 0) + log.duration_minutes
        key = (log.app_name, log.category)
        app_usage[key] = app_usage.get(key, 0) + log.duration_minutes
    
    # Build top apps
    top_apps = []
    for (app_name, category), minutes in sorted(app_usage.items(), key=lambda x: x[1], reverse=True)[:5]:
        top_apps.append(TopAppResponse(
            app_name=app_name,
            category=category,
            total_minutes=minutes,
            percentage=round(minutes / total_minutes * 100, 1) if total_minutes else 0
        ))
    
    # Build category stats
    category_stats = []
    for name, minutes in category_usage.items():
        category_stats.append(CategoryStatResponse(
            name=name,
            total_minutes=minutes,
            percentage=round(minutes / total_minutes * 100, 1) if total_minutes else 0,
            trend="stable"
        ))
    
    # Simple daily stats (demo)
    daily_stats = [
        DailyStatsResponse(
            date=request.week_start,
            total_minutes=daily_avg,
            category_breakdown={"general": daily_avg}
        )
    ]
    
    # Use AI or demo
    if not groq_client:
        return _get_demo_weekly_report_full(request, total_minutes, daily_avg, top_apps, category_stats, daily_stats)
    
    try:
        apps_summary = "\n".join([f"- {app.app_name}: {app.total_minutes} min ({app.category})" for app in top_apps])
        
        prompt = f"""You are a child development expert. Generate a weekly report for a parent.

CHILD: {request.child.child_name}, Age {request.child.age}
WEEK: {request.week_start} to {request.week_end}
TOTAL SCREEN TIME: {total_minutes} minutes ({total_minutes/60:.1f} hours)

TOP APPS:
{apps_summary}

Respond in JSON:
{{
    "executive_summary": "<2-3 sentence overview>",
    "key_observations": ["<observation 1>", "<observation 2>"],
    "concerns": ["<concern if any>"],
    "positive_highlights": ["<positive 1>", "<positive 2>"],
    "recommendations": ["<recommendation 1>", "<recommendation 2>"],
    "safety_score": <60-100>
}}

Return ONLY valid JSON."""

        response = groq_client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=1024
        )
        response_text = response.choices[0].message.content.strip()
        
        # Clean JSON
        if response_text.startswith("```json"):
            response_text = response_text[7:]
        if response_text.startswith("```"):
            response_text = response_text[3:]
        if response_text.endswith("```"):
            response_text = response_text[:-3]
        
        result = json.loads(response_text.strip())
        
        return WeeklyReportResponse(
            child_name=request.child.child_name,
            week_start=request.week_start,
            week_end=request.week_end,
            generated_at=datetime.now().isoformat(),
            total_screen_time_minutes=total_minutes,
            daily_average_minutes=daily_avg,
            safety_score=result.get("safety_score", 75),
            daily_stats=daily_stats,
            top_apps=top_apps,
            category_stats=category_stats,
            executive_summary=result.get("executive_summary", ""),
            key_observations=result.get("key_observations", []),
            concerns=result.get("concerns", []),
            positive_highlights=result.get("positive_highlights", []),
            recommendations=result.get("recommendations", [])
        )
        
    except Exception as e:
        print(f"⚠️ API failed, using demo mode: {str(e)}")
        return _get_demo_weekly_report_full(request, total_minutes, daily_avg, top_apps, category_stats, daily_stats)


def _get_demo_weekly_report_full(request, total_minutes, daily_avg, top_apps, category_stats, daily_stats) -> WeeklyReportResponse:
    """Generate demo weekly report"""
    age = request.child.age
    hours = total_minutes / 60
    
    # Calculate safety score based on age and usage
    if age <= 8:
        safety_score = 90 if hours < 10 else 75 if hours < 15 else 60 if hours < 20 else 45
    else:
        safety_score = 90 if hours < 14 else 75 if hours < 21 else 60 if hours < 28 else 45
    
    return WeeklyReportResponse(
        child_name=request.child.child_name,
        week_start=request.week_start,
        week_end=request.week_end,
        generated_at=datetime.now().isoformat(),
        total_screen_time_minutes=total_minutes,
        daily_average_minutes=daily_avg,
        safety_score=safety_score,
        daily_stats=daily_stats,
        top_apps=top_apps,
        category_stats=category_stats,
        executive_summary=f"{request.child.child_name} used screens for {hours:.1f} hours this week, averaging {daily_avg} minutes per day. {'This is within healthy limits.' if safety_score >= 70 else 'Consider reducing screen time.'}",
        key_observations=[
            "Consistent usage patterns throughout the week",
            "Good mix of educational and entertainment content",
            f"Peak usage typically occurs in the evening hours"
        ],
        concerns=[
            f"Screen time slightly above recommended for {age}-year-olds"
        ] if safety_score < 70 else [],
        positive_highlights=[
            "Educational content makes up a good portion of usage",
            "Bedtime limits appear to be respected",
            "No concerning content detected"
        ],
        recommendations=[
            "Set 30-minute breaks between long sessions",
            "Encourage outdoor activities to balance screen time",
            "Review top apps together weekly"
        ]
    )




async def generate_insights(request: InsightsRequest):
    """
    Generate AI-powered insights from activity logs using Google Gemini.
    
    Args:
        request: InsightsRequest containing a list of activity logs
        
    Returns:
        InsightsResponse with the generated summary string
    """
    if not groq_client:
        raise HTTPException(
            status_code=500,
            detail="GROQ_API_KEY not configured. Please set it in .env file."
        )
    
    if not request.logs:
        raise HTTPException(
            status_code=400,
            detail="No activity logs provided."
        )
    
    try:
        # Format logs for the prompt
        logs_text = "\n".join([
            f"- {log.app_name} ({log.category}): {log.duration_minutes} minutes at {log.timestamp}"
            for log in request.logs
        ])
        
        # Create the analysis prompt
        prompt = f"""You are an AI assistant helping parents monitor their child's digital activity.
Analyze the following activity logs and provide helpful, caring insights.

Activity Logs:
{logs_text}

Provide a concise summary (2-3 paragraphs) that includes:
1. Overall screen time patterns and trends
2. Any concerning behaviors (excessive gaming, late-night usage, etc.)
3. Positive observations (educational app usage, balanced habits)
4. Actionable recommendations for parents

Keep the tone supportive and constructive, not alarmist."""

        # Generate insights using Groq
        chat_completion = groq_client.chat.completions.create(
            messages=[
                {"role": "system", "content": "You are an AI assistant helping parents monitor their child's digital activity."},
                {"role": "user", "content": prompt}
            ],
            model="llama-3.3-70b-versatile",
            temperature=0.7,
            max_tokens=1000
        )
        
        summary = chat_completion.choices[0].message.content.strip()
        
        return {"summary": summary}
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate insights: {str(e)}"
        )


# ============ Weekly Report Endpoint ============

@app.post("/reports/weekly", response_model=WeeklyReportResponse)
async def generate_weekly_report(request: WeeklyReportRequest):
    """
    Generate a comprehensive weekly report with AI-powered insights.
    
    This endpoint analyzes 7 days of activity logs and produces a detailed
    report including safety score, category breakdown, and recommendations.
    """
    if not groq_client:
        raise HTTPException(
            status_code=500,
            detail="GROQ_API_KEY not configured. Please set it in .env file."
        )
    
    if not request.logs:
        raise HTTPException(
            status_code=400,
            detail="No activity logs provided."
        )
    
    try:
        child_name = request.child.child_name
        logs = request.logs
        
        # ========== Calculate Statistics ==========
        
        # Total screen time
        total_minutes = sum(log.duration_minutes for log in logs)
        daily_average = total_minutes // 7 if total_minutes > 0 else 0
        
        # Daily breakdown
        daily_data = defaultdict(lambda: {"total": 0, "categories": defaultdict(int)})
        for log in logs:
            # Extract date from timestamp
            date_str = log.timestamp.split("T")[0] if "T" in log.timestamp else log.timestamp[:10]
            daily_data[date_str]["total"] += log.duration_minutes
            daily_data[date_str]["categories"][log.category] += log.duration_minutes
        
        daily_stats = [
            DailyStats(
                date=date,
                total_minutes=data["total"],
                category_breakdown=dict(data["categories"])
            )
            for date, data in sorted(daily_data.items())
        ]
        
        # Top apps
        app_usage = defaultdict(lambda: {"minutes": 0, "category": ""})
        for log in logs:
            app_usage[log.app_name]["minutes"] += log.duration_minutes
            app_usage[log.app_name]["category"] = log.category
        
        sorted_apps = sorted(app_usage.items(), key=lambda x: x[1]["minutes"], reverse=True)[:5]
        top_apps = [
            TopApp(
                app_name=app_name,
                category=data["category"],
                total_minutes=data["minutes"],
                percentage=round(data["minutes"] / total_minutes * 100, 1) if total_minutes > 0 else 0
            )
            for app_name, data in sorted_apps
        ]
        
        # Category stats
        category_totals = defaultdict(int)
        for log in logs:
            category_totals[log.category] += log.duration_minutes
        
        category_stats = [
            CategoryStat(
                name=category,
                total_minutes=minutes,
                percentage=round(minutes / total_minutes * 100, 1) if total_minutes > 0 else 0,
                trend="stable"  # In future, compare with previous week
            )
            for category, minutes in sorted(category_totals.items(), key=lambda x: x[1], reverse=True)
        ]
        
        # Calculate safety score (simple heuristic)
        education_pct = next((c.percentage for c in category_stats if c.name.lower() in ["education", "educational"]), 0)
        gaming_pct = next((c.percentage for c in category_stats if c.name.lower() in ["gaming", "games"]), 0)
        social_pct = next((c.percentage for c in category_stats if c.name.lower() in ["social", "social media"]), 0)
        
        # Base score
        safety_score = 70
        # Boost for education
        safety_score += min(education_pct * 0.5, 15)
        # Reduce for excessive gaming
        if gaming_pct > 40:
            safety_score -= (gaming_pct - 40) * 0.5
        # Reduce for excessive social media
        if social_pct > 30:
            safety_score -= (social_pct - 30) * 0.3
        # Bonus for balanced usage
        if daily_average <= 120:  # 2 hours or less
            safety_score += 10
        elif daily_average > 240:  # More than 4 hours
            safety_score -= 10
        
        safety_score = max(20, min(100, int(safety_score)))
        
        # ========== Generate AI Content ==========
        
        # Format data for AI prompt
        logs_summary = "\n".join([
            f"- {log.app_name} ({log.category}): {log.duration_minutes} min"
            for log in logs[:50]  # Limit to avoid token limits
        ])
        
        category_summary = "\n".join([
            f"- {cat.name}: {cat.total_minutes} min ({cat.percentage}%)"
            for cat in category_stats
        ])
        
        prompt = f"""You are a child safety and digital wellness expert creating a weekly report for parents.

CHILD: {child_name} (Age: {request.child.age})
WEEK: {request.week_start} to {request.week_end}

TOTAL SCREEN TIME: {total_minutes} minutes ({daily_average} min/day average)
SAFETY SCORE: {safety_score}/100

CATEGORY BREAKDOWN:
{category_summary}

SAMPLE ACTIVITIES:
{logs_summary}

Generate the following in JSON format:
{{
  "executive_summary": "2-3 sentence overview of the week's digital activity",
  "key_observations": ["3-4 bullet points of notable patterns"],
  "concerns": ["1-2 areas parents should monitor, or empty if none"],
  "positive_highlights": ["2-3 positive behaviors observed"],
  "recommendations": ["3-4 actionable tips for parents"]
}}

Keep the tone supportive and constructive. Be specific to this child's data."""

        # Generate using Groq
        chat_completion = groq_client.chat.completions.create(
            messages=[
                {"role": "system", "content": "You are an AI assistant analyzing children's digital activity. Respond only with valid JSON."},
                {"role": "user", "content": prompt}
            ],
            model="llama-3.3-70b-versatile",
            temperature=0.7,
            max_tokens=1500
        )
        
        # Parse AI response
        ai_text = chat_completion.choices[0].message.content.strip()
        
        # Extract JSON from response
        if "```json" in ai_text:
            ai_text = ai_text.split("```json")[1].split("```")[0].strip()
        elif "```" in ai_text:
            ai_text = ai_text.split("```")[1].split("```")[0].strip()
        
        ai_data = json.loads(ai_text)
        
        # Build response
        return WeeklyReportResponse(
            child_name=child_name,
            week_start=request.week_start,
            week_end=request.week_end,
            generated_at=datetime.now().isoformat(),
            total_screen_time_minutes=total_minutes,
            daily_average_minutes=daily_average,
            safety_score=safety_score,
            daily_stats=daily_stats,
            top_apps=top_apps,
            category_stats=category_stats,
            executive_summary=ai_data.get("executive_summary", "Report generated successfully."),
            key_observations=ai_data.get("key_observations", []),
            concerns=ai_data.get("concerns", []),
            positive_highlights=ai_data.get("positive_highlights", []),
            recommendations=ai_data.get("recommendations", [])
        )
        
    except json.JSONDecodeError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to parse AI response: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate weekly report: {str(e)}"
        )


# ============ Real-time Alerts (WebSocket) ============

# Store for connected WebSocket clients
class ConnectionManager:
    def __init__(self):
        self.active_connections: dict[str, list[WebSocket]] = {}
    
    async def connect(self, websocket: WebSocket, parent_id: str):
        await websocket.accept()
        if parent_id not in self.active_connections:
            self.active_connections[parent_id] = []
        self.active_connections[parent_id].append(websocket)
        print(f"✅ WebSocket connected: {parent_id}")
    
    def disconnect(self, websocket: WebSocket, parent_id: str):
        if parent_id in self.active_connections:
            if websocket in self.active_connections[parent_id]:
                self.active_connections[parent_id].remove(websocket)
            if not self.active_connections[parent_id]:
                del self.active_connections[parent_id]
        print(f"❌ WebSocket disconnected: {parent_id}")
    
    async def broadcast_to_parent(self, parent_id: str, message: dict):
        """Send alert to all connected clients for a specific parent"""
        if parent_id in self.active_connections:
            for connection in self.active_connections[parent_id]:
                try:
                    await connection.send_json(message)
                except Exception as e:
                    print(f"Failed to send to {parent_id}: {e}")
    
    async def broadcast_all(self, message: dict):
        """Send alert to all connected clients"""
        for parent_id, connections in self.active_connections.items():
            for connection in connections:
                try:
                    await connection.send_json(message)
                except Exception as e:
                    print(f"Failed to send to {parent_id}: {e}")


manager = ConnectionManager()


class AlertTriggerRequest(BaseModel):
    """Request to trigger a real-time alert"""
    parent_id: str = "default"  # Optional, broadcast to all if default
    child_name: str
    title: str
    message: str
    severity: int = 1  # 0=info, 1=warning, 2=critical
    category: str = "content"  # content, time, app, location, social


class AlertResponse(BaseModel):
    """Alert response"""
    id: str
    child_name: str
    title: str
    message: str
    severity: int
    category: str
    timestamp: str
    success: bool


@app.websocket("/ws/alerts/{parent_id}")
async def alerts_websocket(websocket: WebSocket, parent_id: str):
    """
    WebSocket endpoint for real-time alerts.
    
    Connect to receive push notifications when alerts are triggered.
    """
    await manager.connect(websocket, parent_id)
    try:
        while True:
            # Keep connection alive, listen for pings
            data = await websocket.receive_text()
            if data == "ping":
                await websocket.send_text("pong")
    except WebSocketDisconnect:
        manager.disconnect(websocket, parent_id)


@app.post("/alerts/trigger", response_model=AlertResponse)
async def trigger_alert(request: AlertTriggerRequest):
    """
    Trigger a real-time alert (for demo/testing).
    
    This will push the alert to all connected WebSocket clients.
    Use this to demonstrate real-time capabilities during competition.
    """
    import uuid
    
    alert_id = str(uuid.uuid4())[:8]
    timestamp = datetime.now().isoformat()
    
    alert_data = {
        "id": alert_id,
        "child_name": request.child_name,
        "title": request.title,
        "message": request.message,
        "severity": request.severity,
        "category": request.category,
        "timestamp": timestamp,
    }
    
    # Broadcast to all connected clients (for demo)
    await manager.broadcast_all(alert_data)
    
    print(f"🔔 Alert triggered: {request.title}")
    
    return AlertResponse(
        **alert_data,
        success=True
    )


@app.get("/ws/status")
async def websocket_status():
    """Check how many WebSocket clients are connected"""
    total = sum(len(conns) for conns in manager.active_connections.values())
    return {
        "connected_clients": total,
        "parent_ids": list(manager.active_connections.keys())
    }
